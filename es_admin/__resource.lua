-- Manifest
resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

-- Requiring essentialmode
--dependency 'essentialmode'

client_script 'cl_admin.lua'
server_scripts {'sv_admin.lua',
                '@mysql-async/lib/MySQL.lua'}