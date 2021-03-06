class WidgetsController < ApplicationController
  # GET /widgets
  # GET /widgets.json
  def index
    @widgets = Widget.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @widgets }
    end
  end

  # GET /widgets/1
  # GET /widgets/1.json
  def show
    @widget = Widget.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @widget }
    end
  end

  # GET /widgets/new
  # GET /widgets/new.json
  def new
    @widget = Widget.new
    @widget.build_data_source()
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @widget }
    end
  end

  # GET /widgets/1/edit
  def edit
    @widget = Widget.find(params[:id])
  end

  # POST /widgets
  # POST /widgets.json
  def create
    @widget = Widget.new(params[:widget])
    @widget.id = params[:widget][:id]

    respond_to do |format|
      if @widget.save
        format.html { redirect_to @widget, notice: 'Widget was successfully created.' }
        format.json { render json: @widget, status: :created, location: @widget }
      else
        format.html { render action: "new" }
        format.json { render json: @widget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /widgets/1
  # PUT /widgets/1.json
  def update
    @widget = Widget.find(params[:id])

    respond_to do |format|
      if @widget.update_attributes(params[:widget])
        format.html { redirect_to widgets_path, notice: 'Widget was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @widget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /widgets/1
  # DELETE /widgets/1.json
  def destroy
    @widget = Widget.find(params[:id])
    @widget.destroy

    respond_to do |format|
      format.html { redirect_to widgets_url }
      format.json { head :no_content }
    end
  end
  
  def sort
    Widget.sort! params[:widget_id_array]
    respond_to do |format|
      format.html { redirect_to widgets_path }
      format.json { head :no_content }
    end
  end
  
  def record_all_samples
    Widget.record_all_samples!
    render nothing: true
  end
  
  def process_samples
    @widget = Widget.find(params[:id])
    @days = params[:days].to_i || 1
    logger.debug "params: #{params}"
    logger.debug "days: #{@days}"
    #data = @widget.process_samples(1)
    data = {}
    data['samples'] = @widget.samples.where("created_at > :days", {:days => @days.day.ago}).order('date ASC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: data }
    end
  end
end
