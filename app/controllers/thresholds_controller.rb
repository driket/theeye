class ThresholdsController < ApplicationController
  # GET /thresholds
  # GET /thresholds.json
  def index
    @thresholds = Threshold.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @thresholds }
    end
  end

  # GET /thresholds/1
  # GET /thresholds/1.json
  def show
    @threshold = Threshold.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @threshold }
    end
  end

  # GET /thresholds/new
  # GET /thresholds/new.json
  def new
    @threshold = Threshold.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @threshold }
    end
  end

  # GET /thresholds/1/edit
  def edit
    @threshold = Threshold.find(params[:id])
  end

  # POST /thresholds
  # POST /thresholds.json
  def create
    @threshold = Threshold.new(params[:threshold])

    respond_to do |format|
      if @threshold.save
        format.html { redirect_to @threshold, notice: 'Threshold was successfully created.' }
        format.json { render json: @threshold, status: :created, location: @threshold }
      else
        format.html { render action: "new" }
        format.json { render json: @threshold.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /thresholds/1
  # PUT /thresholds/1.json
  def update
    @threshold = Threshold.find(params[:id])

    respond_to do |format|
      if @threshold.update_attributes(params[:threshold])
        format.html { redirect_to @threshold, notice: 'Threshold was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @threshold.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /thresholds/1
  # DELETE /thresholds/1.json
  def destroy
    @threshold = Threshold.find(params[:id])
    @threshold.destroy

    respond_to do |format|
      format.html { redirect_to thresholds_url }
      format.json { head :no_content }
    end
  end
end
