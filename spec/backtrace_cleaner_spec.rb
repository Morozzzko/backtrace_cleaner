# frozen_string_literal: true

require 'backtrace_cleaner'

RSpec.describe BacktraceCleaner do
  subject { BacktraceCleaner.new }

  describe 'filter' do
    before do
      subject.add_filter { |line| line.gsub('/my/prefix', '') }
    end

    example 'backtrace should filter all lines in a backtrace, removing prefixes' do
      expect(subject.clean(['/my/prefix/my/class.rb', '/my/prefix/my/module.rb'])).to eql(
        ['/my/class.rb', '/my/module.rb']
      )
    end

    example 'backtrace cleaner should allow removing filters' do
      subject.remove_filters!
      expect(subject.clean(['/my/prefix/my/class.rb']).first).to eql('/my/prefix/my/class.rb')
    end

    example 'backtrace should contain unaltered lines if they dont match a filter' do
      expect(subject.clean(['/my/other_prefix/my/class.rb']).first).to eql('/my/other_prefix/my/class.rb')
    end
  end

  describe 'silencer' do
    before do
      subject.add_silencer { |line| line.include?('mongrel') }
    end

    example 'backtrace should not contain lines that match the silencer' do
      expect(
        subject.clean(['/mongrel/class.rb', '/other/class.rb', '/mongrel/stuff.rb'])
      ).to eql(['/other/class.rb'])
    end

    example 'backtrace cleaner should allow removing silencer' do
      subject.remove_silencers!
      expect(subject.clean(['/mongrel/stuff.rb'])).to eql(['/mongrel/stuff.rb'])
    end
  end

  describe 'multiple silencers' do
    before do
      subject.add_silencer { |line| line.include?('mongrel') }
      subject.add_silencer { |line| line.include?('yolo') }
    end

    example 'backtrace should not contain lines that match the silencers' do
      expect(
        subject.clean(['/mongrel/class.rb', '/other/class.rb', '/mongrel/stuff.rb', '/other/yolo.rb'])
      ).to eql(['/other/class.rb'])
    end

    example 'backtrace should only contain lines that match the silencers' do
      expect(
        subject.clean(
          ['/mongrel/class.rb', '/other/class.rb', '/mongrel/stuff.rb', '/other/yolo.rb'],
          :noise
        )
      ).to eql(['/mongrel/class.rb', '/mongrel/stuff.rb', '/other/yolo.rb'])
    end
  end

  describe 'filters and silencers' do
    before do
      subject.add_filter   { |line| line.gsub('/mongrel', '') }
      subject.add_silencer { |line| line.include?('mongrel') }
    end

    example 'backtrace should not silence lines that has first had their silence hook filtered out' do
      expect(subject.clean(['/mongrel/class.rb'])).to eql(['/class.rb'])
    end
  end

  describe 'default filter and silencer' do
    example 'should format installed gems correctly' do
      backtrace = ["#{Gem.default_dir}/gems/nosuchgem-1.2.3/lib/foo.rb"]
      result = subject.clean(backtrace, :all)
      expect(result.first).to eql('nosuchgem (1.2.3) lib/foo.rb')
    end

    example 'should format installed gems not in Gem.default_dir correctly' do
      target_dir = Gem.path.detect { |p| p != Gem.default_dir }
      # skip this test if default_dir is the only directory on Gem.path
      if target_dir
        backtrace = ["#{target_dir}/gems/nosuchgem-1.2.3/lib/foo.rb"]
        result = subject.clean(backtrace, :all)
        expect(result.first).to eql('nosuchgem (1.2.3) lib/foo.rb')
      end
    end

    example 'should format gems installed by bundler' do
      backtrace = ["#{Gem.default_dir}/bundler/gems/nosuchgem-1.2.3/lib/foo.rb"]
      result = subject.clean(backtrace, :all)
      expect(result.first).to eql('nosuchgem (1.2.3) lib/foo.rb')
    end

    example 'should silence gems from the backtrace' do
      backtrace = ["#{Gem.path[0]}/gems/nosuchgem-1.2.3/lib/foo.rb"]
      result = subject.clean(backtrace)
      expect(result).to be_empty
    end

    example 'should silence stdlib' do
      backtrace = ["#{RbConfig::CONFIG['rubylibdir']}/lib/foo.rb"]
      result = subject.clean(backtrace)
      expect(result).to be_empty
    end
  end
end
