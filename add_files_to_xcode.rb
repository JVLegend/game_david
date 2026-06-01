require 'xcodeproj'

project_path = '/Users/iaparamedicos/Documents/GitHub/game_david/DaviTheAnointed/DaviTheAnointed.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Add RankingScene.swift
group_scenes = project.main_group.find_subpath('DaviTheAnointed/Scenes', false)
unless group_scenes.files.any? { |f| f.path == 'RankingScene.swift' }
  file_ref_scene = group_scenes.new_file('RankingScene.swift')
  target.add_file_references([file_ref_scene])
end

# Add RankingManager.swift
group_managers = project.main_group.find_subpath('DaviTheAnointed/Managers', false)
unless group_managers.files.any? { |f| f.path == 'RankingManager.swift' }
  file_ref_manager = group_managers.new_file('RankingManager.swift')
  target.add_file_references([file_ref_manager])
end

project.save
puts "Files added successfully!"
