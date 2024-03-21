from django.db import models


class Blog(models.Model):
	title = models.CharField(max_length=256)
	description = models.TextField()

	def __str__(self) -> str:
		return f"{self.title[:30]}{'...' if len(self.title) > 30 else ''}"
