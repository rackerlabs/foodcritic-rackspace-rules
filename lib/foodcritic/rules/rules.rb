require 'yaml' # included in ruby
require 'foodcritic/chef'

rule 'RACK001', 'Missing "# Copyright" declaration' do
  tags %w(style rackspace)
  cookbook do |path|
    matches = []

    recipes = Dir["#{path}/{#{standard_cookbook_subdirs.join(',')}}/**/*.rb"]
    recipes += Dir["#{path}/*.rb"]
    recipes.collect do |recipe|

      # skip things without 'recipes' in the path
      next if !recipe.include? '/recipes/'

      # need to scan comments for this rule
      lines = File.readlines(recipe)
      next if lines.collect do |line|
        line.include?('# Copyright')
      end.compact.flatten.include? true

      matches << {
        :filename => recipe,
        :matched => recipe,
        :line => 0,
        :column => 0
      }
    end # recipe

    matches
  end # cookbook
end # rule

rule 'RACK002', 'Recipe contains a single include_recipe' do
  tags %w(style rackspace)
  cookbook do |path|
    matches = []

    recipes = Dir["#{path}/{#{standard_cookbook_subdirs.join(',')}}/**/*.rb"]
    recipes += Dir["#{path}/*.rb"]
    recipes.collect do |recipe|

      # skip things without 'recipes' in the path
      next if !recipe.include? '/recipes/'

      # unfortunately, we need to scan source for this rule
      # as the AST of a recipe could span multiple files
      lines = File.readlines(recipe)
      non_comments = lines.collect do |line|
        next if line.nil?
        next if line.strip.nil?
        next if line.strip.start_with? '#'
        next if line.strip == ""
        line.strip
      end.compact

      next if non_comments.length != 1
      next if !non_comments.first.start_with? "include_recipe"

      matches << {
        :filename => recipe,
        :matched => recipe,
        :line => 0,
        :column => 0
      }
    end # recipe

    matches
  end # cookbook
end # rule

rule 'RACK003', 'Cookbook is missing a standard file' do
  tags %w(style rackspace)

  expected_files = %w(README.md metadata.rb LICENSE Gemfile Berksfile Rakefile Thorfile Guardfile .kitchen.yml .rubocop.yml CHANGELOG.md )

  cookbook do |path|
    matches = []
    expected_files.each do |f|
      next unless !File.exist?("#{path}/#{f}")

      matches << {
          :filename => "#{f}",
          :matched => 'missing',
          :line => 0,
          :column => 0
      }
    end
    matches
  end # cookbook
end # rule

rule 'RACK004', 'Cookbook is missing a default test suite' do
  tags %w(style rackspace)

  search_files = %w( .kitchen.yml )
  default_suite_found = false

  cookbook do |path|
    matches = []

    search_files.each do |f|
      next unless File.exist?("#{path}/#{f}")

      # if we can't parse .kitchen.yml for some reason, don't fail on it
      # we may just be seeing ERB used in it. if it's a true error, test-kitchen
      # will blow up on it anyway
      begin
        kitchen_config = YAML.load_file("#{path}/#{f}")
      rescue
        default_suite_found = true # don't blow up
        next
      end

      next if !kitchen_config.has_key?('suites')

      kitchen_config['suites'].each do |test_suite|
        next unless test_suite.has_key?('name')
        default_suite_found = true if test_suite['name'] == 'default'
      end
    end

    if !default_suite_found
      matches << {
          :filename => ".kitchen.yml",
          :matched => 'missing default test suite',
          :line => 0,
          :column => 0
      }
    end

    matches
  end # cookbook
end # rule

rack005_required_fields = {
  'maintainer' => 'Rackspace',
  'maintainer_email' => 'rackspace-cookbooks@rackspace.com',
}
req_fields = StringIO.new
rack005_required_fields.each do |k, v|
  req_fields << " #{k}='#{v}'"
end
rule 'RACK005', "Cookbook metadata must have#{req_fields.string}" do
  tags %w(style rackspace)
  metadata do |ast, filename|
    rack005_required_fields.map do |field, value|
      ast.xpath(%Q(//command[ident/@value='#{field}']/descendant::tstring_content[@value!='#{value}']))
    end
  end # metadata
end # rule

rule 'RACK006', 'Cookbook rspec (chefspec) tests should be in ./test/unit/spec, not ./spec' do
  tags %w(style rackspace)

  default_suite_found = false

  cookbook do |path|
    next unless File.exist?("#{path}/spec")
    matches = []
    matches << {
        :filename => false,
        :matched => 'should not be here',
        :line => 0,
        :column => 0
    }
    matches
  end # cookbook
end # rule

rule 'RACK007', "Cookbook must be licensed Apache 2.0 (public) or All rights reserved (private)" do
  tags %w(style rackspace)
  apache = 'Apache 2.0'
  arr = 'All rights reserved'
  metadata do |ast, filename|
    matches = []
    license_value = ast.xpath(%Q(//command[ident/@value='license']/descendant::tstring_content/@value))
    if license_value.nil? || !(license_value.to_s == apache || license_value.to_s == arr)
      matches << ast.xpath(%Q(//command[ident/@value='license']/descendant::tstring_content))
    end
    matches
  end # metadata
end # rule

rule 'RACK008', 'Files expected by Support must exist' do
  tags %w(style rackspace-support)
  expected_files = %w(Berksfile.lock)

  cookbook do |path|
    matches = []
    expected_files.each do |f|
      next unless !File.exist?("#{path}/#{f}")

      matches << {
        filename: "#{f}",
        matched: 'missing',
        line: => 0,
        column: => 0
      }
    end
    matches
  end # cookbook
end

rule 'RACK009', 'Berksfile.lock must not be in .gitignore' do
  tags %w(style rackspace-support)

  cookbook do
    matches = []

    gitignore = '.gitignore'
    lines = File.readlines(gitignore)

    lines.each do |line|
      if line.include?('Berksfile.lock')
        matches << {
          filename: gitignore,
          matched: 'Berksfile.lock should not be here',
          line: lines.index(line),
          column: 0
        }
      end
    end
    matches
  end
end # rule
