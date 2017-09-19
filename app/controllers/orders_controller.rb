class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order
  before_action :authorize_user, except: [:new, :index]

  def show
  end

  def new
  end

  def create
    @order = Order.new(order_params.for_creation_by(current_user))

    if @order.save
      render status: :created
    else
      render status: :unprocessable_entity
    end
  end

  def update
    update_params = order_params.send("for_#{update_type}_by", current_user)

    respond_to do |format|
      if update_params && @order.update(update_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @order.confirmed? || !current_user.belongs_to?(@order.purchaser)
      redirect_to orders_url
    else
      @order.destroy
      head :no_content
    end
  end

  private
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
        redirect_to order_path(@order) if action_name == "show"
      else
        redirect_to root_path
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
