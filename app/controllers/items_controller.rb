class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vars
  before_action :authorize_user

  def index
    @items = @company.items
  end

  def create
    @item = Item.new(item_params)

    render status: @item.save ? :created : :unprocessable_entity
  end

  def new
    @item = Item.new
  end

  def edit
  end

  def show
  end

  def update
    render status: @item.update(item_params) ? :ok : :unprocessable_entity
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to company_items_path(@company), notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_vars
      @company = Company.find(params[:company_id])
      @item = Item.find(params[:id]) if params.key?(:id)
    end

    def authorize_user
      if current_user.belongs_to?(@company)
        return
      elsif current_user.is_purchaser?(@company)
        redirect_to company_items_path(@company) unless action_name =~ /(index|show)/
      else
        redirect_to company_path(@company)
      end
    end

    def item_params
      params.require(:item).permit(:name, :ref_code, :price, :unit_size)
        .merge(supplier_id: params[:company_id])
    end
end
