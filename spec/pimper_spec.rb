require 'spec_helper'

describe Pimper do
  describe "#initialize" do
    it "should take a github user, a github project and a changelog" do
      g = Pimper.new('gregbell', 'activeadmin', 'ChangeLog')
      g.user.should == 'gregbell'
      g.project.should == 'activeadmin'
      g.changelog.should == 'ChangeLog'
    end
  end

  describe "#better_changelog" do
    let(:user) { 'gregbell' }
    let(:project) { 'activeadmin' }

    let(:better_changelog) { Pimper.new(user, project, changelog).better_changelog }

    subject { better_changelog }

    context "when the changelog does not contain any reference to issues or users and no extra newline" do
      let(:changelog) { "ChangeLog\n" }

      it "should return the original changelog with an extra newline" do
        better_changelog.should == changelog + "\n"
      end
    end

    context "when the changelog already includes an extra newline" do
      let(:changelog) { "ChangeLog\n\n" }

      it "should return the original changelog" do
        better_changelog.should == changelog
      end
    end

    context "when the changelog contains an issue number" do
      let(:changelog) { 'Pull Request #123: Add I18n.' }

      it "should wrap the issue number to make a link" do
        better_changelog.should include("[#123][]")
      end

      it "should append the link definition at the end of the changelog" do
        better_changelog.split("\n").last.should == "[#123]: https://github.com/gregbell/activeadmin/issues/123"
      end
    end

    context "when the changelog contains a contributor" do
      let(:changelog) { 'New feature by @pc-re_ux' }

      it "should wrap the issue number to make a link" do
        better_changelog.should include("[@pc-re_ux][]")
      end

      it "should append the link definition at the end of the changelog" do
        better_changelog.split("\n").last.should == "[@pc-re_ux]: https://github.com/pc-re_ux"
      end
    end

    context "when the changelog contains issue numbers or contributors which are links" do
      let(:changelog) { '[@pcreux][] closes [#123][]' }

      it "should leave them alone" do
        better_changelog.should include("[@pcreux][] closes [#123][]")
      end
    end

    context "when the changelog already contains issue numbers, link definitions and custom links" do
      let(:changelog) { <<-EOS
# New entry
You know what? @pcreux closed issue #300!

# Previous entries
You know what? [@pcreux][] closed issue [#123][].
And this is my link, don't touch it: [Adequate][http://adequatehq.com]

<!--- The following link definition list is generated by PimpMyChangelog --->
[#123]: https://github.com/gregbell/activeadmin/issues/123
[@pcreux]: https://github.com/pcreux
EOS
      }

      let(:better_changelog) { Pimper.new('gregbell', 'activeadmin', changelog).better_changelog }

      it "should regenerate the link definition but leave the existing links alone" do
        (better_changelog + "\n").should == <<-EOS
# New entry
You know what? [@pcreux][] closed issue [#300][]!

# Previous entries
You know what? [@pcreux][] closed issue [#123][].
And this is my link, don't touch it: [Adequate][http://adequatehq.com]

<!--- The following link definition list is generated by PimpMyChangelog --->
[#123]: https://github.com/gregbell/activeadmin/issues/123
[#300]: https://github.com/gregbell/activeadmin/issues/300
[@pcreux]: https://github.com/pcreux
EOS
      end
    end
  end

end

