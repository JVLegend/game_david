require 'xcodeproj'

project_path = '/Users/iaparamedicos/Documents/GitHub/game_david/DaviTheAnointed/DaviTheAnointed.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Try to find the group by path
davi_group = project.main_group.children.find { |c| c.path == 'DaviTheAnointed' }
if davi_group
  textures_group = davi_group.children.find { |c| c.path == 'Resources/Textures' }
  if textures_group
    ['wolf.png', 'background_forest.png', 'ground_grass.png', 'background_menu.png', 'map_marker.png', 'button_texture.png', '15_1_davi_com_funda.png', '15_1_davi_jovem.png', 'botao_pedra.png', 'davijovem.png', 'davirei.png', 'leao.png', 'pergaminho.png'].each do |filename|
      unless textures_group.files.any? { |f| f.path == filename }
        file_ref = textures_group.new_file(filename)
        target.add_file_references([file_ref])
        puts "Added #{filename} to project."
      end
    end
  else
    puts "Could not find Resources/Textures group"
  end
else
  puts "Could not find DaviTheAnointed group"
end

project.save
puts "Project updated successfully!"
