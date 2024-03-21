from django.test import TestCase
from .models import Blog


class BlogTestCase(TestCase):
    def setUp(self):
        Blog.objects.create(title="First Blog", description="Test Description")

    def test_blogs_created(self):
        """Blogs that can speak are correctly identified"""
        first_blog = Blog.objects.first()
        self.assertEqual(first_blog.title, "First Blog")
