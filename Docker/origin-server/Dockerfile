FROM python:3.9-slim

WORKDIR /app

# Install Flask
RUN pip install Flask

# Copy the Flask app
COPY app.py /app/

# Copy the images directory
COPY images /app/images

# Expose port 5000
EXPOSE 5000

# Run the Flask app
CMD ["python", "app.py"]
