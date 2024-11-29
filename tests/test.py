import asyncio
import aiohttp
import base64
import hmac
import hashlib
import random
import json
from itertools import product

SECRET_KEY_BASE64 = "c2VjcmV0X2tleV9leGFtcGxlX3YxMjM="
SECRET_KEY = base64.b64decode(SECRET_KEY_BASE64).decode()

IMAGES = [f"cat.{i}.jpg" for i in range(1, 51)]
IMAGE_WEIGHTS = [75 if i <= 10 else 1 for i in range(1, 51)]  #  %75 weight for first 10 images
WIDTHS = [400, 600, 800]
HEIGHTS = [400, 600, 800]

TOTAL_REQUESTS = 10000
CONCURRENT_REQUESTS = 1000
BASE_URL = "http://localhost:8080"

async def generate_hmac(data):
    """HMAC-SHA256 ile imzalama"""
    signature = hmac.new(
        SECRET_KEY.encode(), data.encode(), hashlib.sha256
    ).digest()
    # URL-safe Base64 encoding
    return base64.urlsafe_b64encode(signature).decode().rstrip("=")

def precompute_hmacs():
    hmac_dict = {}
    for image, width, height in product(IMAGES, WIDTHS, HEIGHTS):
        data = f"/images/{image}?width={width}&height={height}"
        hmac_signature = hmac.new(
            SECRET_KEY.encode(), data.encode(), hashlib.sha256
        ).digest()
        hmac_safe = base64.urlsafe_b64encode(hmac_signature).decode().rstrip("=")
        hmac_dict[f"{image}_{width}_{height}"] = hmac_safe

    with open("hmac_cache.json", "w") as f:
        json.dump(hmac_dict, f)
    print(f"Precomputed HMACs saved for {len(hmac_dict)} combinations.")

async def make_request(session, i, hmac_cache):
    """Hızlı istek gönderimi için önceden hesaplanmış HMAC'leri kullan"""
    image = random.choices(IMAGES, weights=IMAGE_WEIGHTS, k=1)[0]
    resize = random.choices([True, False], weights=[20, 80])[0]

    if resize:
        width = random.choice(WIDTHS)
        height = random.choice(HEIGHTS)
        key = f"{image}_{width}_{height}"
        hmac_signature = hmac_cache[key]
        url = f"{BASE_URL}/images/{image}?width={width}&height={height}&hmac={hmac_signature}"
        request_type = "RESIZE"
    else:
        url = f"{BASE_URL}/images/{image}"
        request_type = "ORIGINAL"

    try:
        async with session.get(url) as response:
            cache_status = response.headers.get("X-Cache-Status", "MISS")
            print(f"Request {i}: {request_type} {image}, Status: {response.status}, Cache: {cache_status}")
            return response.status, cache_status
    except Exception as e:
        print(f"Request {i} failed: {e}")
        return None, "ERROR"

async def main():
    with open("hmac_cache.json", "r") as f:
        hmac_cache = json.load(f)

    connector = aiohttp.TCPConnector(limit=CONCURRENT_REQUESTS)
    async with aiohttp.ClientSession(connector=connector) as session:
        tasks = [make_request(session, i, hmac_cache) for i in range(1, TOTAL_REQUESTS + 1)]
        results = await asyncio.gather(*tasks)

    hits = sum(1 for _, cache in results if cache == "HIT")
    misses = sum(1 for _, cache in results if cache == "MISS")
    print("\n--- Results ---")
    print(f"Total Requests: {TOTAL_REQUESTS}")
    print(f"Cache Hits: {hits}")
    print(f"Cache Misses: {misses}")
    if TOTAL_REQUESTS > 0:
        hit_ratio = (hits / TOTAL_REQUESTS) * 100
        print(f"Cache Hit Ratio: {hit_ratio:.2f}%")

if __name__ == "__main__":
    precompute_hmacs()

    asyncio.run(main())
