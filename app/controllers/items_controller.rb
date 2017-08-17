class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vars
  before_action :authorize_user

  def index
    @items = @company.items
  end

  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        format.html { redirect_to [@item.supplier, @item], notice: 'item was successfully created.' }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @item = Item.new
  end

  def edit
  end

  def show
  end

  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to [@item.supplier, @item], notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
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
      if current_user.is_admin?(@company)
        return
      elsif current_user.is_purchaser?(@company) || current_user.belongs_to?(@company)
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
