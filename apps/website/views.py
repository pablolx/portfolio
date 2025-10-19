from django.shortcuts import render
import requests
from .models import Project

def index(request):
    projects = Project.objects.order_by("-created_at")
    return render(request, "index.html", {"projects": projects})



def portfolio(request):
    github_user = "SEU_USUARIO_GITHUB"
    response = requests.get(f"https://api.github.com/users/{github_user}/repos")
    repos = response.json() if response.status_code == 200 else []

    context = {
        "repos": repos,
    }
    return render(request, "index.html", context)