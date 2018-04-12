class Submission < ApplicationRecord
  include Markdownable
  before_validation :generate_short_url

  belongs_to :challenge
  belongs_to :participant, optional: true
  has_many :submission_files, dependent: :destroy
  has_many :submission_grades, dependent: :destroy
  has_many :submission_comments, dependent: :destroy
  accepts_nested_attributes_for :submission_files,
    reject_if: lambda { |f| f[:submission_file_s3_key].blank? },
    allow_destroy: true
  has_many :votes, as: :votable

  as_enum :grading_status,
    [:ready, :submitted, :initiated, :graded, :failed], map: :string

  validates :participant_id,            presence: true
  validates :challenge_id,              presence: true
  validates :grading_status,            presence: true
  validate :clef_validations

  def clef_validations
    return true unless self.challenge.organizer.clef?
    if clef_method_description.length < 5
      errors.add(:clef_method_description,
        'Must be at least 5 characters.')
    end
  end

  after_create do
    rnd = self.challenge.challenge_rounds.where('start_dttm <= ? and end_dttm >= ?',self.created_at,self.created_at).first
    if rnd.present?
      self.update(challenge_round_id: rnd.id)
    end
    Scenic.database.refresh_materialized_view(
      :previous_leaderboards,
      concurrently: false,
      cascade: false)
    Scenic.database.refresh_materialized_view(
      :previous_ongoing_leaderboards,
      concurrently: false,
      cascade: false)
  end

  def ready?
    self.grading_status == :ready
  end

  def submitted?
    self.grading_status == :submitted
  end

  def graded?
    self.grading_status == :graded
  end

  def failed?
    self.grading_status == :failed
  end

  def initiated?
    self.grading_status == :initiated
  end

  CLEF_RETRIEVAL_TYPES = {
    'Visual' => :visual,
    'Textual' => :textual,
    'Mixed (Textual and Visual)' => :mixed,
    'Not applicable' => :not_applicable
  }

  CLEF_RUN_TYPES = {
    'Automatic' => :automatic,
    'Feedback or / and Human Assistance' => :feedback,
    'Manual' => :manual
  }


  private
  def generate_short_url
    if self.short_url.blank?
      short_url = nil
      begin
        short_url = SecureRandom.hex(6)
      end while (Submission.exists?(short_url: short_url))
      self.short_url = short_url
    end
  end

end
