class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order
  before_action :authorize_user

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params.for_creation_by(current_user))
    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    update_params = order_params.send("for_#{update_type}_by", current_user)

    respond_to do |format|
      if update_params && @order.update(update_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    if @order.confirmed? || !current_user.belongs_to?(@order.purchaser)
      redirect_to orders_url
    else
      @order.destroy
      respond_to do |format|
        format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find_by(id: params[:id]) ||
        Order.new(purchaser: Company.find_by(id: params.dig(:order, :purchaser_id)), 
                  supplier: Company.find_by(id: params.dig(:order, :supplier_id)))
    end

    def authorize_user
      if @order.purchaser && @order.supplier && \
          current_user.belongs_to?(@order.purchaser)
        return
      elsif current_user.belongs_to?(@order.supplier)
        redirect_to orders_path if action_name =~ /(new|create)/
      else
        redirect_to home_path
      end
    end

    def order_params
      filtered_params = params.fetch(:order).merge(params.permit(:id))
      OrderParams.new(filtered_params)
    end

    def update_type
      params.fetch(:update_action)
    end
end
