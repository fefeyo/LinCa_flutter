import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { Request, Response } from 'express';

// ⚠️ initializeApp は index.ts で1回だけ呼ぶ前提
// ここでは呼ばない

export const distributeClosedBetaBadge = onRequest(
  { region: 'us-central1' },
  async (_req: Request, res: Response) => {
    const db = admin.firestore();

    // 全ユーザー取得
    const usersSnap = await db.collection('users').get();

    const batch = db.batch();

    usersSnap.docs.forEach(doc => {
      const uid = doc.id;

      const badgeRef = db
        .collection('users')
        .doc(uid)
        .collection('badges')
        .doc('closed_beta_tester'); // ← 固定ID（重複しない）

      // 中身なし・冪等（何回叩いても増えない）
      batch.set(badgeRef, {}, { merge: true });
    });

    await batch.commit();

    res.json({
      distributed: usersSnap.size,
      badgeId: 'closed_beta_tester',
    });
  }
);
