# frozen_string_literal: true

require 'spec_helper'

describe 'project' do
  include_context 'command line'

  describe 'help' do
    it 'displays help' do
      expect(`"#{project}" help`).to include 'project - GitHub project info tool.'
    end
  end

  pending '--token'
  pending '--no-cache'
  pending '--debug'
end
