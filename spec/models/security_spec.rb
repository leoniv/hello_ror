require 'rails_helper'

Rails.application.eager_load!

RSpec.describe 'security model' do
  ApplicationRecord.descendants.each do |model|
    describe model do
      context 'should detect' do
        it 'HTML/JavaScrip injection', security: 'xss' do
          skip('FIXME')
        end

        it 'SQL injection', security: 'sql' do
          skip('FIXME')
        end
      end
    end
  end
end
