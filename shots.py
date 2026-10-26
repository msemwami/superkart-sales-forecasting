# Captures the Streamlit app (running in this Codespace) after a single and a batch prediction
import asyncio, os, sys
from playwright.async_api import async_playwright
URL = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8501"
async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch()
        pg = await b.new_page(viewport={"width": 1200, "height": 1900})
        await pg.goto(URL); await pg.wait_for_selector("text=Predict", timeout=60000)
        await pg.wait_for_timeout(2000)
        await pg.get_by_role("button", name="Predict", exact=True).click()
        await pg.wait_for_selector("text=Predicted Product Store Sales Total", timeout=30000)
        await pg.wait_for_timeout(1000)
        await pg.screenshot(path="screenshots/st_single.png")
        await pg.set_input_files("input[type=file]", os.path.abspath("Batch_Data_SuperKart.csv"))
        await pg.wait_for_selector("text=Predict for Batch", timeout=30000)
        await pg.get_by_role("button", name="Predict for Batch").click()
        await pg.wait_for_selector("text=Predictions completed successfully", timeout=30000)
        await pg.wait_for_timeout(2000)
        await pg.screenshot(path="screenshots/st_batch_full.png")
        await b.close()
asyncio.run(main())
