class ProbesController < ApplicationController
  
  # GET /probes
  # GET /probes.json
  def index
    @probes = Probe.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @probes }
    end
  end

  # GET /probes/1
  # GET /probes/1.json
  def show
    @probe = Probe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @probe }
    end
  end

  # GET /probes/new
  # GET /probes/new.json
  def new
    @probe = Probe.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @probe }
    end
  end

  # GET /probes/1/edit
  def edit
    @probe = Probe.find(params[:id])
  end

  # POST /probes
  # POST /probes.json
  def create
    @probe = Probe.new(params[:probe])

    respond_to do |format|
      if @probe.save
        format.html { redirect_to @probe, notice: 'Probe was successfully created.' }
        format.json { render json: @probe, status: :created, location: @probe }
      else
        format.html { render action: "new" }
        format.json { render json: @probe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /probes/1
  # PUT /probes/1.json
  def update
    @probe = Probe.find(params[:id])

    respond_to do |format|
      if @probe.update_attributes(params[:probe])
        format.html { redirect_to '/', notice: 'Probe was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @probe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /probes/1
  # DELETE /probes/1.json
  def destroy
    @probe = Probe.find(params[:id])
    @probe.destroy

    respond_to do |format|
      format.html { redirect_to probes_url }
      format.json { head :no_content }
    end
  end
end
