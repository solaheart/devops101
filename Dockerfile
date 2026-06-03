# ============================================================
# Stage 1: Builder
# ============================================================
FROM python:3.12-slim AS builder

WORKDIR /app

# Install dependencies only (layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --target=/app/deps -r requirements.txt

# Copy source code
COPY . .

# ============================================================
# Stage 2: Runtime (Distroless)
# ============================================================
FROM gcr.io/distroless/python3-debian12

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /app/deps /app/deps

# Copy application source
COPY --from=builder /app .

# Set PYTHONPATH to include deps
ENV PYTHONPATH=/app/deps

# Distroless ไม่มี shell → ต้องใช้ exec form เท่านั้น
ENTRYPOINT ["python3", "main.py"]