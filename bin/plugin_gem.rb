# frozen_string_literal: true

module PluginGem
  def self.load(path, name, version, opts = nil)
    opts ||= {}

    gems_path = File.dirname(path) + "/gems/#{RUBY_VERSION}"

    spec_path = gems_path + "/specifications"

    if opts[:local]
      spec_file = spec_path + "/omnievent-0.1.0.gemspec" if name.include?('omnievent-0.1.0')
      spec_file = spec_path + "/omnievent-icalendar-0.1.0.gemspec" if name.include?('omnievent-icalendar-0.1.0')
      spec_file = spec_path + "/omnievent-eventbrite-0.1.0.gemspec" if name.include?('omnievent-eventbrite-0.1.0')
      spec_file = spec_path + "/omnievent-humanitix-0.1.0.gemspec" if name.include?('omnievent-humanitix-0.1.0')
      spec_file = spec_path + "/omnievent-eventzilla-0.1.0.gemspec" if name.include?('omnievent-eventzilla-0.1.0')
    else
      spec_file  = spec_path + "/#{name}-#{version}"
      spec_file += "-#{opts[:platform]}" if opts[:platform]
      spec_file += ".gemspec"
    end

    unless File.exist? spec_file
      command  = "gem install #{name} -v #{version} -i #{gems_path} --no-document --ignore-dependencies --no-user-install"
      command += " --source #{opts[:source]}" if opts[:source]
      puts command

      Bundler.with_unbundled_env do
        puts `#{command}`
      end
    end

    if File.exist? spec_file
      Gem.path << gems_path
      Gem::Specification.load(spec_file).activate

      unless opts[:require] == false
        require opts[:require_name] ? opts[:require_name] : name
      end
    else
      puts "You are specifying the gem #{name} in #{path}, however it does not exist!"
      puts "Looked for: #{spec_file}"
      exit(-1)
    end
  end
end
