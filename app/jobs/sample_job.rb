class SampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    logger.info "サンプルジョブを実行しました"
  end
end
