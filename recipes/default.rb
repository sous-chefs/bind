# frozen_string_literal: true
#
# Cookbook Name:: bind
# Recipe:: default
#
# Copyright 2011, Gerald L. Hevener, Jr, M.S.
# Copyright 2011, Eric G. Wolfe
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
#

bind_service 'default' do
  action [:create, :start]
end

bind_config 'default' do
  options [
    'allow-query { trusted-nets; }',
    'recursion yes',
    'allow-recursion { trusted-nets; }',
  ]
end

bind_acl 'trusted-nets' do
  entries %w(
    localhost
    localnets)
end
