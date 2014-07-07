require 'pp'

rule 'RACK001', 'Missing license or copyright declarations' do
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
        line.include?('Rackspace')
        line.include?('# Copyright')
        line.include?('http://www.apache.org/licenses/LICENSE-2.0')
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


