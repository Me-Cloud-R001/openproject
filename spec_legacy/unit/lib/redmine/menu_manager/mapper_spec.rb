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
require_relative '../../../../legacy_spec_helper'

describe Redmine::MenuManager::Mapper do
  it 'pushes onto root' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_overview, { controller: 'projects', action: 'show' }, {}

    menu_mapper.exists?(:test_overview)
  end

  it 'pushes onto parent' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_overview, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_child, { controller: 'projects', action: 'show' }, parent: :test_overview

    assert menu_mapper.exists?(:test_child)
    assert_equal :test_child, menu_mapper.find(:test_child).name
  end

  it 'pushes onto grandparent' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_overview, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_child, { controller: 'projects', action: 'show' }, parent: :test_overview
    menu_mapper.push :test_grandchild, { controller: 'projects', action: 'show' }, parent: :test_child

    assert menu_mapper.exists?(:test_grandchild)
    grandchild = menu_mapper.find(:test_grandchild)
    assert_equal :test_grandchild, grandchild.name
    assert_equal :test_child, grandchild.parent.name
  end

  it 'pushes first' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_second, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_third, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_fourth, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_fifth, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_first, { controller: 'projects', action: 'show' }, first: true

    root = menu_mapper.find(:root)
    assert_equal 5, root.children.size
    { 0 => :test_first, 1 => :test_second, 2 => :test_third, 3 => :test_fourth, 4 => :test_fifth }.each do |position, name|
      refute_nil root.children[position]
      assert_equal name, root.children[position].name
    end
  end

  it 'pushes before' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_first, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_second, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_fourth, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_fifth, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_third, { controller: 'projects', action: 'show' }, before: :test_fourth

    root = menu_mapper.find(:root)
    assert_equal 5, root.children.size
    { 0 => :test_first, 1 => :test_second, 2 => :test_third, 3 => :test_fourth, 4 => :test_fifth }.each do |position, name|
      refute_nil root.children[position]
      assert_equal name, root.children[position].name
    end
  end

  it 'pushes after' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_first, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_second, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_third, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_fifth, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_fourth, { controller: 'projects', action: 'show' }, after: :test_third

    root = menu_mapper.find(:root)
    assert_equal 5, root.children.size
    { 0 => :test_first, 1 => :test_second, 2 => :test_third, 3 => :test_fourth, 4 => :test_fifth }.each do |position, name|
      refute_nil root.children[position]
      assert_equal name, root.children[position].name
    end
  end

  it 'pushes last' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_first, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_second, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_third, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_fifth, { controller: 'projects', action: 'show' }, last: true
    menu_mapper.push :test_fourth, { controller: 'projects', action: 'show' }, {}

    root = menu_mapper.find(:root)
    assert_equal 5, root.children.size
    { 0 => :test_first, 1 => :test_second, 2 => :test_third, 3 => :test_fourth, 4 => :test_fifth }.each do |position, name|
      refute_nil root.children[position]
      assert_equal name, root.children[position].name
    end
  end

  it 'existses for child node' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_overview, { controller: 'projects', action: 'show' }, {}
    menu_mapper.push :test_child, { controller: 'projects', action: 'show' }, parent: :test_overview

    assert menu_mapper.exists?(:test_child)
  end

  it 'existses for invalid node' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_overview, { controller: 'projects', action: 'show' }, {}

    assert !menu_mapper.exists?(:nothing)
  end

  it 'finds' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_overview, { controller: 'projects', action: 'show' }, {}

    item = menu_mapper.find(:test_overview)
    assert_equal :test_overview, item.name
    assert_equal({ controller: 'projects', action: 'show' }, item.url)
  end

  it 'finds missing' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_overview, { controller: 'projects', action: 'show' }, {}

    item = menu_mapper.find(:nothing)
    assert_equal nil, item
  end

  it 'deletes' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    menu_mapper.push :test_overview, { controller: 'projects', action: 'show' }, {}
    refute_nil menu_mapper.delete(:test_overview)

    assert_nil menu_mapper.find(:test_overview)
  end

  it 'deletes missing' do
    menu_mapper = Redmine::MenuManager::Mapper.new(:test_menu, {})
    assert_nil menu_mapper.delete(:test_missing)
  end

  specify 'deleting all items' do
    # Exposed by deleting :last items
    Redmine::MenuManager.map :test_menu do |menu|
      menu.push :not_last, OpenProject::Static::Links.help_link
      menu.push :administration, { controller: 'projects', action: 'show' }, last: true
      menu.push :help, OpenProject::Static::Links.help_link, last: true
    end

    expect do
      Redmine::MenuManager.map :test_menu do |menu|
        menu.delete(:administration)
        menu.delete(:help)
        menu.push :test_overview, { controller: 'projects', action: 'show' }, {}
      end
    end.not_to raise_error
  end
end
