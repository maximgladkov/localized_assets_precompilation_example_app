LocalizedAssetsPrecompilationExampleApp::Application.routes.draw do

  scope '(:locale)' do

    root to: 'welcome#index'

  end

end
