class EmergenciesController < ApplicationController
  before_action :create_params_include_unpermitted_keys?, only: [:create]
  before_action :update_params_include_unpermitted_keys?, only: [:update]
  before_action :page_not_found, only: [:new, :edit, :destroy]

  def new; end

  def edit; end

  def destroy; end

  def create
    emergency = Emergency.create(emergency_params)

    if emergency.save
      Responder.dispatch("Fire", params[:emergency][:fire_severity], params[:emergency][:code])
      Responder.dispatch("Medical", params[:emergency][:medical_severity], params[:emergency][:code])
      Responder.dispatch("Police", params[:emergency][:police_severity], params[:emergency][:code])

      render json: emergency, status: 201
    else
      render json: { 'message' => emergency.errors }, status: 422
    end
  end

  def index
    render json: Emergency.all
  end

  def show
    emergency = Emergency.find_by(code: params[:code])

    if emergency
      render json: emergency, serializer: EmergencySerializer, status: 201
    else
      render json: { 'message' => 'record not found' }, status: 404
    end
  end

  def update
    emergency = Emergency.find_by(code: params[:code])

    if emergency.update_attributes(emergency_params)
      render json: emergency, serializer: EmergencySerializer
    else
      render json: { 'message' => emergency.errors }, status: 422
    end
  end

  private

  def create_params_include_unpermitted_keys?
    unpermitted_keys = %w(id resolved_at)

    selected_keys = unpermitted_keys.select do |key|
      params[:emergency].key?(key)
    end

    render json: {
      'message' => 'found unpermitted parameter: ' + selected_keys.join(', ')
    }, status: 422 if selected_keys.length > 0
  end

  def update_params_include_unpermitted_keys?
    unpermitted_keys = %w(code)

    selected_keys = unpermitted_keys.select do |key|
      params[:emergency].key?(key)
    end

    render json: {
      'message' => 'found unpermitted parameter: ' + selected_keys.join(', ')
    }, status: 422 if selected_keys.length > 0
  end

  def emergency_params
    params.require(:emergency).permit(:code, :police_severity, :medical_severity, :fire_severity, :resolved_at)
  end
end
