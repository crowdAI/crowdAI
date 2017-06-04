class CommentsController < ApplicationController
  before_action :authenticate_participant!, only: [:create, :update, :destroy]
  before_action :set_comment, only: [:edit, :update, :destroy]
  before_action :set_topic_and_challenge
  #after_action :notify_subscribers, only: [:create]


  def new
    @challenge = @topic.challenge
    @author = @topic.participant

    @first_comment = @topic.comments.order(created_at: :asc).first
    @comments = @topic.comments.where.not(id: @first_comment.id).order(created_at: :asc)
    @comment = Comment.new(topic_id: @topic_id)
    authorize @comment
   end

  def create
    @comment = @topic.comments.new(comment_params)
    if @comment.save
      redirect_to new_topic_comment_path(@topic), notice: 'Comment was successfully created.'
    else
      render :new
    end
    authorize @comment
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def set_topic_and_challenge
      @topic = Topic.friendly.find(params[:topic_id])
      @challenge = @topic.challenge
    end

    def comment_params
      params.require(:comment).permit(:topic_id, :participant_id, :comment_markdown, :votes, :flagged, :notify)
    end

    def notify_subscribers
      PostNotificationJob.perform_later(@post)
    end
end
