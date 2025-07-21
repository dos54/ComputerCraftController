import { db } from "../config/db";

export function pushToDb(key: string, data: object) {
    db.push(key, data)
}

export async function getFromDb(key: string) {
    return await db.getData(key)
}