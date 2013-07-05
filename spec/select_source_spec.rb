require 'spec_helper'
require_relative './support/bare_object'
require_relative './support/select_source'

describe BareObject do
  let(:obj) { BareObject }

  context 'including FormalWear' do
    before { obj.send(:include, FormalWear) }

    context 'when required_attr is invoked' do
      context 'with a field of type :select' do
        context 'without select_options specified' do
          it 'should raise an error' do
            expect {
              obj.class_eval do
                required_attr unselect_me: {
                  name: 'Broken select',
                  type: :select,
                  source: ->(s) { SelectSource.first },
                }
              end
            }.to raise_error
          end
        end

        context 'with select_options specified' do
          before do
            obj.class_eval do
              required_attr select_me: {
                name: "Selected",
                type: :select,
                source: ->(s) { SelectSource.first },
                select_options: ->(s) { SelectSource.all }
              }
            end
          end

          context 'a new BareObject' do
            subject { BareObject.new }
            context '#required_attributes' do
              it 'includes select_me' do
                subject.required_attributes.keys.should include(:select_me)
              end

              context '[:select_me]' do
                let(:new_obj) { BareObject.new }
                let(:select_me) { new_obj.required_attributes[:select_me] }
                subject { select_me }

                it 'includes a values key' do
                  subject.keys.should include(:values)
                end

                context '[:values]' do
                  subject { select_me[:values] }
                  it 'contains the data specified in the select_options key' do
                    subject.should == SelectSource.all
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end