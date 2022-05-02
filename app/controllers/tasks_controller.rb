class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true).page(params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data @tasks.generate_csv, filename: "tasks-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
    end
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    #モデルのアソシエーションがかかっているからできる記述
    @task = current_user.tasks.new(task_params)

    if params[:back].present?
      render :new
      return
    end

    if @task.save
      logger.debug "task: #{@task.attributes.inspect}"
      TaskMailer.creation_email(@task).deliver_now
      SampleJob.perform_later
      redirect_to root_path, notice: "タスク「#{@task.name}」を登録しました。"
    else
      render :new
    end
  end

  def update
    @task.update(task_params)
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を更新しました。"
  end

  def destroy
    @task.destroy
    head :no_content
  end

  def confirm_new
    @task = current_user.tasks.new(task_params)
    render :new unless @task.valid?
  end

  def import
    #Taskモデルのself.import()メソッドを呼び出している
    current_user.tasks.import(params[:file])
    redirect_to tasks_url, notice: "タスクを追加しました"
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name, :description, :image)
  end
end
