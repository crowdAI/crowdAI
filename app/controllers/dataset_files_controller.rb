class DatasetFilesController < ApplicationController
  before_action :authenticate_participant!
  before_action :set_dataset_file, only: [:destroy]
  before_action :set_challenge

  def index
    if current_participant.admin?
      @dataset_files = @challenge.dataset_files
    else
      @dataset_files = @challenge.dataset_files.where(evaluation: false)
    end
  end

  def show
  end

  def new
    @dataset_file = @challenge.dataset_files.new
    authorize @dataset_file
  end

  def create
    @dataset_file = @challenge.dataset_files.new(dataset_file_params)
    if @dataset_file.save
      redirect_to challenge_dataset_files_path(@challenge, @dataset_file),
                  notice: 'Dataset file was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @dataset_file.destroy
    redirect_to challenge_dataset_files_path(@challenge),
                notice: "Dataset file #{@dataset_file.title} was deleted."
  end

  private
    def set_dataset_file
      @dataset_file = DatasetFile.find(params[:id])
    end

    def set_challenge
      @challenge = Challenge.friendly.find(params[:challenge_id])
    end

    def dataset_file_params
      params.require(:dataset_file).permit(:seq, :description, :evaluation, :title, :dataset_file)
    end

end
