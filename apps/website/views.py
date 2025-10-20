from django.shortcuts import render
import requests
from .models import Project

def index(request):
    projects = Project.objects.order_by("-created_at")
    return render(request, "index.html", {"projects": projects})



def portfolio(request):
    projetos = Project.objects.all()
    return render(request, "index.html", {"projetos": projetos})
