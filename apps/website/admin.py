from django.contrib import admin
from .models import Project

@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ("title", "created_at", "repo_url", "live_url")
    search_fields = ("title", "description")
    list_filter = ("created_at",)
    ordering = ("-created_at",)