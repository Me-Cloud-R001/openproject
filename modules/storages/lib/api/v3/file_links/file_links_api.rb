#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

# This class provides definitions for API routes and endpoints for the file_links namespace. It inherits the
# functionality from the Grape REST API framework. It is mounted in lib/api/v3/root.rb.
# -> /api/v3/file_links/...
module API
  module V3
    module FileLinks
      class FileLinksAPI < ::API::OpenProjectAPI
        # helpers is defined by the grape framework. They make methods from the
        # module available from within the endpoint context.
        helpers API::V3::Utilities::StoragesHelpers

        # The `:resources` keyword defines the API namespace -> /api/v3/file_links/...
        resources :file_links do
          # `route_param` extends the route by a route parameter of the endpoint.
          # The input parameter value is parsed into the `:file_link_id` symbol.
          route_param :file_link_id, type: Integer, desc: 'File link id' do
            # The after validation hook executes after the validation of the request format, but before any execution
            # inside the endpoint context. Hence, it is a good place to actually fetch the handled resource.
            after_validation do
              @file_link = visible_file_links_scope.find(params[:file_link_id])
            end

            # A helper is used to define the behaviour at GET /api/v3/file_links/:file_link_id
            get &::API::V3::Utilities::Endpoints::Show.new(model: ::Storages::FileLink).mount

            # A helper is used to define the behaviour at DELETE /api/v3/file_links/:file_link_id
            delete &::API::V3::Utilities::Endpoints::Delete.new(model: ::Storages::FileLink,
                                                                process_service: ::Storages::FileLinks::DeleteService)
                                                           .mount

            # Additional API definitions are mounted under the current namespace, hence they are
            # appended to /api/v3/file_links/:file_link_id/...
            mount ::API::V3::FileLinks::FileLinksOpenAPI
            mount ::API::V3::FileLinks::FileLinksDownloadAPI
          end
        end
      end
    end
  end
end
