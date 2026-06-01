require 'xcodeproj'

project_path = '/Users/iaparamedicos/Documents/GitHub/game_david/DaviTheAnointed/DaviTheAnointed.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

davi_group = project.main_group.children.find { |c| c.path == 'DaviTheAnointed' }
if davi_group
  textures_group = davi_group.children.find { |c| c.path == 'Resources/Textures' }
  if textures_group
    ['AppIcon.png', 'AppIcon60x60@2x.png', 'AppIcon60x60@3x.png'].each do |filename|
      unless textures_group.files.any? { |f| f.path == filename }
        file_ref = textures_group.new_file(filename)
        target.add_file_references([file_ref])
        puts "Added #{filename} to project."
      end
    end
  end
end

project.save
puts "Icons added to project successfully."
