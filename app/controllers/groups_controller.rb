class GroupsController < ApplicationController
before_action :authenticate_user!, :only => [:new, :create, :edit, :destroy, :update]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def show
    @group = Group.find(params[:id])
    @posts = @group.posts.order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
  end

  def edit
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(group_params)
    @group.user = current_user
    if @group.save
      redirect_to groups_path
    else
      render :new
    end
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      flash[:notice] = "修改成功"
      redirect_to groups_path
    else
      render :edit
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    flash[:alert] = "已删除群组"
    redirect_to groups_path
  end

  def join
    @group = Group.find(params[:id])
    if current_user.is_member_of?(@group)
      flash[:warning] = "你已是本讨论版成员"
    else
      current_user.join!(@group)
      flash[:notice] = "加入讨论版成功"
    end
    redirect_to group_path(@group)
  end

  def quit
    @group = Group.find(params[:id])
    if current_user.is_member_of?(@group)
      current_user.quit!(@group)
      flash[:alert] = "退出讨论版成功"
    else
      flash[:warning] = "你不是讨论版成员，怎么退出"
    end
    redirect_to group_path(@group)
  end

  private

  def group_params
    params.require(:group).permit(:title, :description)
  end

end
