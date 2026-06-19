import { Router } from 'express';
import { communityController } from './community.controller.js';
import { authenticate } from '@shared/middleware/authenticate.js';
import { authorize } from '@shared/middleware/authorize.js';
import { validate } from '@shared/middleware/validate.js';
import { createPostSchema, updatePostSchema, createCommentSchema, updateCommentSchema } from './community.schema.js';
import { Role } from '@prisma/client';

const router: Router = Router();
router.use(authenticate);
router.use(authorize(Role.HEAD_OF_FAMILY));

router.get('/posts', (req, res, next) => communityController.listPosts(req, res, next));
router.get('/posts/:id', (req, res, next) => communityController.getPostById(req, res, next));
router.post('/posts', validate({ body: createPostSchema }), (req, res, next) => communityController.createPost(req, res, next));
router.patch('/posts/:id', validate({ body: updatePostSchema }), (req, res, next) => communityController.updatePost(req, res, next));
router.delete('/posts/:id', (req, res, next) => communityController.deletePost(req, res, next));

router.get('/comments/:postId', (req, res, next) => communityController.listComments(req, res, next));
router.post('/comments', validate({ body: createCommentSchema }), (req, res, next) => communityController.createComment(req, res, next));
router.patch('/comments/:id', validate({ body: updateCommentSchema }), (req, res, next) => communityController.updateComment(req, res, next));
router.delete('/comments/:id', (req, res, next) => communityController.deleteComment(req, res, next));

export default router;
