target 'GaitAuth IFTTT' do
    pod 'UnifyID/GaitAuth'
  end
  
  # Enable library evolution support on all dependent projects.
  post_install do |pi|
      pi.pods_project.targets.each do |t|
          t.build_configurations.each do |config|
              config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
          end
      end
  end