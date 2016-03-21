require 'pipeline/tasks/base_task'
require 'pipeline/util'
require 'find'
require 'pry'

class Pipeline::Npm < Pipeline::BaseTask

  Pipeline::Tasks.add self
  include Pipeline::Util

  def initialize(trigger, tracker)
    super(trigger, tracker)
    @name = "NPM"
    @description = "Node Package Manager"
    @stage = :file
    @labels << "file" << "javascript"
    @results = []
  end

  def run
    directories_with?('package.json').each do |dir|
      Pipeline.notify "#{@name} scanning: #{dir}"
      Dir.chdir(dir) do
        if @tracker.options.has_key?(:npm_registry)
          registry = "--registry #{@tracker.options[:npm_registry]}"
        else
          registry = nil
        end
        @command = "npm install --ignore-scripts #{registry}"
        @results << system(@command)
      end
    end
  end

  def analyze
    begin
      if @results.include? false
        Pipeline.warn 'Error installing javascript dependencies with #{@command}'
      end
    rescue Exception => e
      Pipeline.warn e.message
      Pipeline.warn e.backtrace
    end
  end

  def supported?
    supported = find_executable0('npm')
    unless supported
      Pipeline.notify "Install npm: https://nodejs.org/en/download/"
      return false
    else
      return true
    end
  end

end
