require 'spec_helper'

describe CommentsController do
  context 'when configured' do
    describe 'HTML UI' do
      before :each do
        Factory.create :geewee_config
        @post = Factory.create :post
        @valid_comment_params = {
          :name  => Factory.next(:author_name),
          :email => Factory.next(:email),
          :body  => Factory.next(:content)
        }
        @invalid_comment_params = Hash.new
      end

      def post_create_with_comment hash
        post :create, :post_id => @post, :option => {:preview => 0}, :comment => hash
      end

      describe :create do
        context 'with invalid comment params' do
          it 'should not create a comment' do
            lambda do
              post_create_with_comment @invalid_comment_params
            end.should_not change(Comment, :count)
          end

          it "should redirect to the comment's post path" do
            post_create_with_comment @invalid_comment_params
            response.should redirect_to post_path(@post, :anchor => :new_comment)
          end

          it 'set flash[:comment] for edit' do
            post_create_with_comment @invalid_comment_params
            flash[:comment].should_not be_nil
            flash[:comment].should be_instance_of Comment
          end
        end

        context 'with valid comment params' do
          it 'should create a comment' do
            lambda do
              post_create_with_comment @valid_comment_params
            end.should change(Comment, :count).by(+1)
          end

          it "should redirect to the comment's anchor path" do
            post_create_with_comment @valid_comment_params
            @comment = @post.comments.first
            response.should redirect_to post_path(@post, :anchor => "comment_#{@comment.id}")
          end

          it 'should not set flash[:comment]' do
            post_create_with_comment @valid_comment_params
            flash[:comment].should be_nil
          end
        end
      end
    end
  end

  describe 'JSON API' do
    it 'should test index'       do pending 'JSON API' end
    it 'should test show'        do pending 'JSON API' end
    it 'should test create'      do pending 'JSON API' end
    it 'should test next_unread' do pending 'JSON API' end
    it 'should test destroy'     do pending 'JSON API' end
  end
end
