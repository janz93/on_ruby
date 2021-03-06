require 'spec_helper'

describe ParticipantsController do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  context 'POST :create' do
    before do
      allow(controller).to receive_messages(current_user: user)
    end

    it 'should add a prticipant for current user' do
      expect do
        post :create, params: { event_id: event.to_param }
      end.to change(Participant, :count).by(1)
      expect(flash[:notice]).to_not be_nil
      expect(response).to redirect_to(event)
    end

    context 'with an already participating user' do
      before do
        event.particpate(user)
      end

      it 'should should alert a duplicate flash' do
        expect do
          post :create, params: { event_id: event.to_param }
        end.to change(Participant, :count).by(0)
        expect(flash[:alert]).to_not be_nil
        expect(response).to redirect_to(event)
      end
    end

    context 'with a closed event' do
      let(:event) { create(:closed_event) }

      it 'should should alert a closed flash' do
        expect do
          post :create, params: { event_id: event.to_param }
        end.to change(Participant, :count).by(0)
        expect(flash[:alert]).to_not be_nil
        expect(response).to redirect_to(event)
      end
    end
  end

  context 'DELETE :destroy' do
    before do
      @participant  = create(:participant)
      @event        = @participant.event
      @user         = @participant.user
    end

    it 'should delete a participant for current user' do
      allow(@controller).to receive_messages(current_user: @user)

      expect do
        delete(:destroy, params: { id: @participant.to_param, event_id: @event.to_param })
      end.to change(Participant, :count).by(-1)
      expect(response).to redirect_to(@event)
    end

    it 'should delete a participant for another user' do
      allow(@controller).to receive_messages(current_user: create(:user))

      expect do
        delete(:destroy, params: { id: @participant.to_param, event_id: @event.to_param })
      end.to change(Participant, :count).by(0)
      expect(response).to redirect_to(@event)
    end
  end
end
