class Users < Application
  provides :xml, :js, :yaml
  
  def index
    @users = User.find(:all)
    render @users
  end
  
  def show
    @user = User.find(params[:id])
    render @user
  end
  
  def new
    only_provides :html
    @user = User.new(params[:user])
    render
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      redirect url(:user, @user)
    else
      render :action => :new
    end
  end
  
  def edit
    only_provides :html
    @user = User.find(params[:id])
    render
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect url(:user, @user)
    else
      raise BadRequest
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect url(:users)
    else
      raise BadRequest
    end
  end
end