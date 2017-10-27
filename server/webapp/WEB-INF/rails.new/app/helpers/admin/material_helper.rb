##########################GO-LICENSE-START################################
# Copyright 2014 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################GO-LICENSE-END##################################

module Admin
  module MaterialHelper
    include JavaImports

    def builtin_material_options
      {l.string("SUBVERSION") => SvnMaterialConfig::TYPE,
       l.string("GIT") => GitMaterialConfig::TYPE,
       l.string("MERCURIAL") => HgMaterialConfig::TYPE,
       l.string("P4") => P4MaterialConfig::TYPE,
       l.string("TFS") => com.thoughtworks.go.config.materials.tfs.TfsMaterialConfig::TYPE,
       l.string("PIPELINE") => DependencyMaterialConfig::TYPE,
       l.string("PACKAGE") => PackageMaterialConfig::TYPE
      }
    end

    def scm_material_options
      options = {}
      scm_plugin_ids = SCMMetadataStore.getInstance().getPlugins()
      if (!scm_plugin_ids.isEmpty())
        scm_plugin_ids.each_with_index do |plugin_id, index|
          display_value = SCMMetadataStore.getInstance().displayValue(plugin_id)
          scm = SCM.new(nil, PluginConfiguration.new(plugin_id, "1"), nil);
          options[display_value] = scm.getSCMType()
        end
      end
      options
    end

    def material_options
      builtin_material_options().merge(scm_material_options())
    end

    def scm_material_config_keys(plugin_id)
      configuration = SCMMetadataStore.getInstance().getConfigurationMetadata(plugin_id).list()
      com.google.gson.Gson.new.toJson(configuration.map { |x| x.getKey() })
    end

    def repository_packages_map_from_config
      return @repository_packages_map if @repository_packages_map
      @repository_packages_map = {}
      @original_cruise_config.getPackageRepositories().each do |repo|
        metadata = RepositoryMetadataStore.getInstance().getMetadata(repo.getPluginConfiguration().getId())
        hash = {:name => repo.getName(), :packages => [], :is_plugin_missing => metadata.nil?, :plugin_id => repo.getPluginConfiguration().getId()}
        repo.getPackages().each do |package|
          hash[:packages] << {:name => package.getName(), :id => package.getId()}
        end
        @repository_packages_map[repo.getId()] = hash
      end
      @repository_packages_map
    end

    def package_material_plugins
      plugins = RepositoryMetadataStore.getInstance().getPlugins()
      [["[Select]", ""]] + plugins.to_a
    end
  end
end