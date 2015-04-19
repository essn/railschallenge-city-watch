class RespondersController < ApplicationController
  before_action :create_params_include_unpermitted_keys?, only: [:create]
  before_action :update_params_include_unpermitted_keys?, only: [:update]
  before_action :page_not_found, only: [:new, :edit, :destroy]

  def new; end

  def edit; end

  def destroy; end

  def index
    responders = Responder.all

    if params[:show] == "capacity" 
      render json: {
        capacity: {
          "Fire": [
            Responder.all_responders("Fire"),
            Responder.available_responders("Fire"),
            Responder.on_duty_responders("Fire"),
            Responder.available_and_on_duty_responders("Fire")
            ],
          "Police": [
            Responder.all_responders("Police"),
            Responder.available_responders("Police"),
            Responder.on_duty_responders("Police"),
            Responder.available_and_on_duty_responders("Police")
            ],
          "Medical": [
            Responder.all_responders("Medical"),
            Responder.available_responders("Medical"),
            Responder.on_duty_responders("Medical"),
            Responder.available_and_on_duty_responders("Medical")
            ]
        }
      }
    else
      render json: responders, each_serializer: ResponderSerializer, status: 200
    end
  end

  def create
    responder = Responder.create(responder_params)

    if responder.save
      render json: responder, serializer: ResponderSerializer, status: 201
    else
      render json: { 'message' => responder.errors }, status: 422
    end
  end

  def show
    responder = Responder.find_by(name: params[:name])

    if responder
      render json: responder, serializer: ResponderSerializer, status: 200
    else
      render json: { 'message' => 'record not found' }, status: 404
    end
  end

  def update
    responder = Responder.find_by(name: params[:name])

    if responder.update_attributes(responder_params)
      render json: responder, serializer: ResponderSerializer
    else
      render json: { 'message' => responder.errors }, status: 422
    end
  end

  private

  def responder_params
    params.require(:responder).permit(:name, :type, :capacity, :on_duty, :emergency_code)
  end

  def create_params_include_unpermitted_keys?
    unpermitted_keys = %w(id emergency_code on_duty)

    selected_keys = unpermitted_keys.select do |key|
      params[:responder].key?(key)
    end

    render json: {
      'message' => 'found unpermitted parameter: ' + selected_keys.join(', ')
    }, status: 422 if selected_keys.length > 0
  end

  def update_params_include_unpermitted_keys?
    unpermitted_keys = %w(id emergency_code name capacity type)

    selected_keys = unpermitted_keys.select do |key|
      params[:responder].key?(key)
    end

    render json: {
      'message' => 'found unpermitted parameter: ' + selected_keys.join(', ')
    }, status: 422 if selected_keys.length > 0
  end
end
