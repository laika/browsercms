require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::LinksControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    login_as_cms_admin
  end

  def test_new
    get :new, :section_id => root_section.id
    
    assert_response :success
    assert_equal root_section, assigns(:link).section
  end

  def test_create
    link_count = Link.count
    post :create, :link => { :name => "Test", :url => "http://www.example.com" }, :section_id => root_section.id
    
    assert_redirected_to [:cms, root_section]
    assert_incremented link_count, Link.count
  end

  def test_edit
    create_link

    get :edit, :id => @link.id
    assert_response :success
    assert_equal @link, assigns(:link)
  end

  def test_update
    create_link
    
    put :update, :link => { :name => "Test Updated", :url => "http://www.updated-example.com" }, :id => @link.id
    reset(:link)

    assert_redirected_to [:cms, @link.section]
    assert_equal "Test Updated", @link.name
    assert_equal "http://www.updated-example.com", @link.url
  end

  protected
    def create_link
      @link = Factory(:link, :section => root_section)
    end

end