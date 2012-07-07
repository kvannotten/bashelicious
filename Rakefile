require 'fileutils'

desc "Install Bashelicious"
task :install do
  readfile = File.open(getbashfile, "r").read
  
  containsbashelicious = !readfile.index(/bashelicious/).nil?
  
  if containsbashelicious
    puts "Already installed Bashelicious."
  else
    puts "Installing Bashelicious..."
    FileUtils.cp("Bashelicious", File.expand_path("~/.bashelicious"))
    
    if File.exists? getbashfile
      FileUtils.cp(getbashfile, File.expand_path("~/.bash_profile.bashelicious.backup"))
    end
    
    open(getbashfile, "a") do |f|
      f.puts
      f.puts "# Bashelicious include"
      #f.puts "if [[ -e $HOME/.bashelicous ]]; then"
      f.puts "source $HOME/.bashelicious"
      #f.puts "fi"
      f.puts "############################"
      f.puts
    end
    #IO.popen("source #{getbashfile}")
    puts "Bashelicious installed to your system." 
    puts "#{colorize "Restart", :red} your terminal for the changes to take effect."
    puts colorize "After you restart your terminal the following things become available:", :red
    puts "- Easy directory listings with: #{colorize 'll', :blue}, #{colorize 'la', :blue} and #{colorize 'l', :blue}"
    puts "- Print a treemap of your current directory with #{colorize 'tree', :blue}"
    puts "- Use #{colorize '..', :blue}, #{colorize '...', :blue} and #{colorize '-', :blue} to switch folders"
    puts "- Use #{colorize "compress", :blue} and #{colorize "decompress", :blue} to (un)tar + gzip a file or directory"
    puts "- Your prompt will contain color codes + if you are in a git dir, it will show the branch"
    puts "- Your man pages will be color coded"
    puts "- Your terminal becomes case insensitive, doesn't make the annoying bell sound anymore and allows for single tab completions"
  end
end

desc "Uninstall Bashelicious"
task :uninstall do 
  if File.exist? File.expand_path("~/.bashelicious")
    puts "Uninstalling"
    File.delete(File.expand_path("~/.bashelicious"))
    File.delete(getbashfile)
    FileUtils.move(File.expand_path("~/.bash_profile.bashelicious.backup"), getbashfile)
    #IO.popen("source #{getbashfile}")
    puts "Uninstalled Bashelicious."
    puts "Restart your terminal for the changes to take effect."
  else
    puts "Bashelicious is not installed on this system."
  end
end


def getbashfile
  File.expand_path("~/.bash_profile")
end

  def colorize(text, color_code)
    color = 0
    case color_code
      when :black    
        color = 30
      when :red      
        color = 31
      when :green    
        color = 32
      when :yellow   
        color = 33
      when :blue     
        color = 34
      when :magenta  
        color = 35
      when :cyan     
        color = 36
      when :white    
        color = 37
    end
    "\033[#{color}m#{text}\033[0m"
  end
