require 'pp'

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

  expected_files = %w(README.md metadata.rb LICENSE Gemfile Berksfile Rakefile Thorfile Guardfile .kitchen.yml .rubocop.yml )
  
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
