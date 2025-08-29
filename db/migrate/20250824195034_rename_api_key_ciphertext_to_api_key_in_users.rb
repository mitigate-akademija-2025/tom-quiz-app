class RenameApiKeyCiphertextToApiKeyInUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :api_key_ciphertext, :api_key
  end
end

def api_key_params
  params.require(:user).permit(:api_key)
end

def update_api_key
  if params[:user][:api_key].present?
    if @user.update(api_key_params)
      redirect_to profile_user_path(@user), notice: "API key updated"
    else
      render :edit_api_key, status: :unprocessable_content
    end
  end
end
