import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();

/** ===========================
 *  グループ別バッジ定義
 * =========================== */
const groupBadges = {
  muse: [
    { threshold: 1, id: "muse_lovelibuin" },
    { threshold: 10, id: "muse_oshi" },
    { threshold: 30, id: "muse_geki_oshi" },
  ],
  aqours: [
    { threshold: 1, id: "aqours_no_10" },
    { threshold: 10, id: "aqours_oshi" },
    { threshold: 30, id: "aqours_geki_oshi" },
  ],
  nijigasaki: [
    { threshold: 1, id: "nijigasaki_you" },
    { threshold: 10, id: "nijigasaki_oshi" },
    { threshold: 30, id: "nijigasaki_geki_oshi" },
  ],
  liella: [
    { threshold: 1, id: "liella_like" },
    { threshold: 10, id: "liella_oshi" },
    { threshold: 30, id: "liella_geki_oshi" },
  ],
  ikizulive: [
    { threshold: 1, id: "ikizulive_like" },
    { threshold: 10, id: "ikizulive_oshi" },
    { threshold: 30, id: "ikizulive_geki_oshi" },
  ],
  hasunosora: [
    { threshold: 1, id: "hasunosora_sukisukiclub" },
    { threshold: 10, id: "hasunosora_oshi" },
    { threshold: 30, id: "hasunosora_geki_oshi" },
  ],
} as const;

type GroupId = keyof typeof groupBadges;

/** ===========================
 *  バッジ定義
 * =========================== */
const eventBadges = [
  { threshold: 1, id: "first_event" },
  { threshold: 10, id: "event_10" },
  { threshold: 100, id: "event_100" },
] as const;

const tradeBadges = [
  { threshold: 1, id: "first_trade" },
  { threshold: 10, id: "trade_10" },
  { threshold: 100, id: "trade_100" },
] as const;

/** ===========================
 *  イベント参加時のバッジ付与
 * =========================== */
export const checkBadgeOnParticipation = onDocumentCreated(
  "users/{uid}/participations/{pid}",
  async (event) => {
    const uid = event.params.uid;
    const data = event.data?.data() as { groupSlug?: GroupId };
    const groupId = data.groupSlug;

    const db = admin.firestore();
    const batch = db.batch();

    // === 全体の参加数 ===
    const allEvents = await db.collection(`users/${uid}/participations`).get();
    const eventCount = allEvents.size;

    for (const badge of eventBadges) {
      if (eventCount >= badge.threshold) {
        const ref = db.doc(`users/${uid}/badges/${badge.id}`);
        if (!(await ref.get()).exists) {
          batch.set(
            ref,
            {
              achievedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
        }
      }
    }

    // === グループ別の参加数 ===
    if (groupId && Object.prototype.hasOwnProperty.call(groupBadges, groupId)) {
      const groupEvents = allEvents.docs.filter(
        (doc) => doc.data().groupSlug === groupId
      );
      const groupCount = groupEvents.length;

      for (const badge of groupBadges[groupId]) {
        if (groupCount >= badge.threshold) {
          const ref = db.doc(`users/${uid}/badges/${badge.id}`);
          if (!(await ref.get()).exists) {
            batch.set(
              ref,
              {
                achievedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
          }
        }
      }
    }

    await batch.commit();
  }
);

/** ===========================
 *  LinCa交換時のバッジ付与
 * =========================== */
export const checkBadgeOnFriendTrade = onDocumentCreated(
  "users/{uid}/friends/{friendUid}",
  async (event) => {
    const uid = event.params.uid;
    const db = admin.firestore();
    const batch = db.batch();

    const friendsSnap = await db.collection(`users/${uid}/friends`).get();
    const friendCount = friendsSnap.size;

    for (const badge of tradeBadges) {
      if (friendCount >= badge.threshold) {
        const ref = db.doc(`users/${uid}/badges/${badge.id}`);
        if (!(await ref.get()).exists) {
          batch.set(
            ref,
            {
              achievedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
        }
      }
    }

    await batch.commit();
  }
);
